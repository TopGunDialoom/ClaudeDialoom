import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const { method, url, body, user } = req;
    
    const userId = user ? user.id : 'anonymous';
    const userInfo = user ? `user ${userId}` : 'anonymous user';
    
    this.logger.log(`[${method}] ${url} - Request by ${userInfo}`);
    
    const now = Date.now();
    return next.handle().pipe(
      tap(() => {
        const response = context.switchToHttp().getResponse();
        const delay = Date.now() - now;
        this.logger.log(
          `[${method}] ${url} - Response status ${response.statusCode} - ${delay}ms`,
        );
      }),
    );
  }
}
