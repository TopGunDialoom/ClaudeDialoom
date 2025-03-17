import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('theme_settings')
export class ThemeSettings {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ default: '#3366FF' })
  primaryColor: string;

  @Column({ default: '#333333' })
  secondaryColor: string;

  @Column({ default: '#FFFFFF' })
  backgroundColor: string;

  @Column({ default: '#F5F5F5' })
  surfaceColor: string;

  @Column({ default: '#e74c3c' })
  errorColor: string;

  @Column({ default: '#2ecc71' })
  successColor: string;

  @Column({ default: '#f39c12' })
  warningColor: string;

  @Column({ default: '#3498db' })
  infoColor: string;

  @Column({ default: "'Roboto', sans-serif" })
  fontFamily: string;

  @Column({ default: "'Poppins', sans-serif" })
  headingFontFamily: string;

  @Column({ default: '14px' })
  baseFontSize: string;

  @Column({ default: '4px' })
  borderRadius: string;

  @Column({ type: 'json', nullable: true })
  customCss: any;

  @Column({ nullable: true })
  logoUrl: string;

  @Column({ nullable: true })
  faviconUrl: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
