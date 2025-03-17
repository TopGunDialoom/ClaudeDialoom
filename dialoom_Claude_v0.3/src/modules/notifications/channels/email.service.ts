import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as SendGrid from '@sendgrid/mail';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private readonly isConfigured: boolean;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('SENDGRID_API_KEY') || '';
    this.isConfigured = apiKey && apiKey.startsWith('SG.');
    
    if (this.isConfigured) {
      SendGrid.setApiKey(apiKey);
    } else {
      this.logger.warn('SendGrid API key not properly configured. Email sending will be simulated.');
    }
  }

  async sendEmail(
    to: string,
    subject: string,
    html: string,
    text?: string,
    from?: string,
  ): Promise<void> {
    const defaultFrom = this.configService.get<string>('SENDGRID_FROM_EMAIL') || 'noreply@example.com';
    
    const msg = {
      to,
      from: from || defaultFrom,
      subject,
      text: text || '',
      html,
    };
    
    if (!this.isConfigured) {
      this.logger.log(`[SIMULATED EMAIL] To: ${to}, Subject: ${subject}`);
      return;
    }
    
    try {
      await SendGrid.send(msg);
    } catch (error) {
      this.logger.error('Error sending email:', error);
      if (error.response) {
        this.logger.error(error.response.body);
      }
      // No relanzamos el error para que la aplicación pueda continuar funcionando
    }
  }
}
