import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  UseGuards,
  Req,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { StripeService } from './stripe.service';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { Public } from '../../common/guards/public.guard';

@ApiTags('payments')
@Controller('payments')
@ApiBearerAuth()
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
    private readonly stripeService: StripeService,
  ) {}

  @Get()
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get all transactions (admin only)' })
  findAll() {
    return this.paymentsService.findAll();
  }

  @Get('me')
  @ApiOperation({ summary: 'Get current user transactions' })
  findUserTransactions(@Req() req) {
    return this.paymentsService.findByUser(req.user.id);
  }

  @Get('stats')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get payment statistics (admin only)' })
  getStats() {
    return this.paymentsService.getTransactionStats();
  }

  @Post('create-intent')
  @ApiOperation({ summary: 'Create a payment intent' })
  createPaymentIntent(
    @Req() req,
    @Body() paymentData: {
      hostId: string;
      amount: number;
      reservationId: string;
      description: string;
    },
  ) {
    return this.paymentsService.createPaymentIntent(
      req.user.id,
      paymentData.hostId,
      paymentData.amount,
      paymentData.reservationId,
      paymentData.description,
    );
  }

  @Post('create-connect-account')
  @ApiOperation({ summary: 'Create a Stripe Connect account for a host' })
  async createConnectAccount(
    @Req() req,
    @Body() data: { 
      country?: string;
      refreshUrl: string;
      returnUrl: string;
    },
  ) {
    const accountId = await this.stripeService.createConnectAccount(
      req.user.email,
      data.country || 'ES',
    );
    
    const accountLinkUrl = await this.stripeService.getAccountLinkUrl(
      accountId,
      data.refreshUrl,
      data.returnUrl,
    );
    
    return { accountId, accountLinkUrl };
  }

  @Post('refund/:id')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Refund a transaction (admin only)' })
  refundTransaction(
    @Param('id') id: string,
    @Body('reason') reason: string,
  ) {
    return this.paymentsService.refundTransaction(id, reason);
  }

  @Post('process-releases')
  @Roles(UserRole.ADMIN, UserRole.SUPERADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Process pending payments to be released (admin only)' })
  processReleases() {
    return this.paymentsService.processReleasePendingPayments();
  }

  @Public()
  @Post('webhook')
  @ApiOperation({ summary: 'Stripe webhook handler' })
  async handleWebhook(@Req() request) {
    const sig = request.headers['stripe-signature'];
    
    try {
      const event = await this.stripeService.constructWebhookEvent(
        request.rawBody,
        sig,
      );
      
      switch (event.type) {
        case 'payment_intent.succeeded':
          const paymentIntent = event.data.object;
          const pi = paymentIntent as any;
          if (pi && pi.id) {
            await this.paymentsService.handlePaymentIntentSucceeded(pi.id);
          }
          break;
        // Handle other events as needed
      }
      
      return { received: true };
    } catch (err) {
      console.error('Webhook error:', err.message);
      throw err;
    }
  }
}
