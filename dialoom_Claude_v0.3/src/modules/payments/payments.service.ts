import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual, IsNull } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Transaction, TransactionStatus, TransactionType } from './entities/transaction.entity';
import { StripeService } from './stripe.service';
import { UsersService } from '../users/users.service';
import { HostsService } from '../hosts/hosts.service';
import { addDays } from 'date-fns';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Transaction)
    private transactionsRepository: Repository<Transaction>,
    private stripeService: StripeService,
    private usersService: UsersService,
    private hostsService: HostsService,
    private configService: ConfigService,
  ) {}

  async findAll(): Promise<Transaction[]> {
    return this.transactionsRepository.find({
      relations: ['user', 'host'],
    });
  }

  async findById(id: string): Promise<Transaction> {
    const transaction = await this.transactionsRepository.findOne({
      where: { id },
      relations: ['user', 'host'],
    });
    
    if (!transaction) {
      throw new NotFoundException(`Transaction with ID ${id} not found`);
    }
    
    return transaction;
  }

  async findByUser(userId: string): Promise<Transaction[]> {
    return this.transactionsRepository.find({
      where: [
        { userId },
        { hostId: userId },
      ],
      relations: ['user', 'host'],
    });
  }

  async createPaymentIntent(
    userId: string,
    hostId: string,
    amount: number,
    reservationId: string,
    description: string,
  ): Promise<any> {
    const user = await this.usersService.findById(userId);
    const host = await this.hostsService.findById(hostId);
    
    if (!user.stripeCustomerId) {
      const customerId = await this.stripeService.createCustomer(
        user.email,
        `${user.firstName} ${user.lastName}`,
      );
      await this.usersService.update(userId, { stripeCustomerId: customerId });
      user.stripeCustomerId = customerId;
    }
    
    if (!host.stripeConnectId) {
      throw new BadRequestException('Host Stripe account not set up');
    }
    
    // Calculate commission and VAT
    const commissionRate = this.configService.get<number>('stripe.commissionRate', 0.10);
    const vatRate = this.configService.get<number>('stripe.vatRate', 0.21);
    
    const commissionAmount = amount * commissionRate;
    const vatAmount = commissionAmount * vatRate;
    const applicationFeeAmount = commissionAmount + vatAmount;
    const netAmount = amount - applicationFeeAmount;
    
    // Create Stripe PaymentIntent
    const paymentIntent = await this.stripeService.createPaymentIntent(
      amount,
      'EUR',
      user.stripeCustomerId,
      host.stripeConnectId,
      description,
      applicationFeeAmount,
    );
    
    // Create transaction record
    const transaction = this.transactionsRepository.create({
      type: TransactionType.PAYMENT,
      userId,
      hostId,
      reservationId,
      amount,
      commissionAmount,
      vatAmount,
      netAmount,
      status: TransactionStatus.PENDING,
      stripePaymentIntentId: paymentIntent.id,
    });
    
    await this.transactionsRepository.save(transaction);
    
    return {
      clientSecret: paymentIntent.client_secret,
      transactionId: transaction.id,
    };
  }

  async handlePaymentIntentSucceeded(paymentIntentId: string): Promise<Transaction> {
    const transaction = await this.transactionsRepository.findOne({
      where: { stripePaymentIntentId: paymentIntentId },
    });
    
    if (!transaction) {
      throw new NotFoundException(`Transaction with payment intent ${paymentIntentId} not found`);
    }
    
    const paymentIntent = await this.stripeService.getPaymentIntent(paymentIntentId);
    
    transaction.status = TransactionStatus.COMPLETED;
    
    // Usar una verificación más segura con typecasting
    const paymentIntentAny = paymentIntent as any;
    if (paymentIntentAny &&
        paymentIntentAny.charges &&
        paymentIntentAny.charges.data &&
        paymentIntentAny.charges.data.length > 0) {
      transaction.stripeChargeId = paymentIntentAny.charges.data[0].id;
    }
    
    return this.transactionsRepository.save(transaction);
  }

  async processReleasePendingPayments(): Promise<Transaction[]> {
    const retentionDays = this.configService.get<number>('stripe.retentionDays', 7);
    const retentionDate = addDays(new Date(), -retentionDays);
    
    const pendingTransactions = await this.transactionsRepository.find({
      where: {
        status: TransactionStatus.COMPLETED,
        isReleased: false,
        createdAt: LessThanOrEqual(retentionDate),
      },
    });
    
    const releasedTransactions: Transaction[] = [];
    
    for (const transaction of pendingTransactions) {
      transaction.isReleased = true;
      transaction.releasedAt = new Date();
      
      await this.transactionsRepository.save(transaction);
      
      releasedTransactions.push(transaction);
    }
    
    return releasedTransactions;
  }

  async refundTransaction(transactionId: string, reason: string): Promise<Transaction> {
    const transaction = await this.findById(transactionId);
    
    if (transaction.status !== TransactionStatus.COMPLETED) {
      throw new BadRequestException('Only completed transactions can be refunded');
    }
    
    if (!transaction.stripePaymentIntentId) {
      throw new BadRequestException('Transaction has no associated payment intent');
    }
    
    const refund = await this.stripeService.refundPayment(transaction.stripePaymentIntentId);
    
    transaction.status = TransactionStatus.REFUNDED;
    transaction.notes = reason;
    
    return this.transactionsRepository.save(transaction);
  }

  async getTransactionStats() {
    const totalTransactions = await this.transactionsRepository.count({
      where: { status: TransactionStatus.COMPLETED },
    });
    
    const result = await this.transactionsRepository
      .createQueryBuilder('transaction')
      .select('SUM(transaction.amount)', 'totalAmount')
      .addSelect('SUM(transaction.commissionAmount)', 'totalCommission')
      .addSelect('SUM(transaction.vatAmount)', 'totalVat')
      .where('transaction.status = :status', { status: TransactionStatus.COMPLETED })
      .getRawOne();
    
    return {
      totalTransactions,
      totalAmount: result.totalAmount || 0,
      totalCommission: result.totalCommission || 0,
      totalVat: result.totalVat || 0,
      totalRevenue: (result.totalCommission || 0) + (result.totalVat || 0),
    };
  }
}
