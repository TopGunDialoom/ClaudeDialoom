import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class I18nService {
  private translations: Record<string, any> = {};
  private defaultLocale = 'es';

  constructor() {
    this.loadTranslations();
  }

  private loadTranslations() {
    const localesDir = path.join(process.cwd(), 'locales');
    
    if (!fs.existsSync(localesDir)) {
      console.warn('Locales directory not found, translations will not be available');
      return;
    }
    
    try {
      const localeFiles = fs.readdirSync(localesDir);
      
      for (const file of localeFiles) {
        if (file.endsWith('.json') || file.endsWith('.yaml')) {
          const locale = file.split('.')[0];
          const filePath = path.join(localesDir, file);
          const content = fs.readFileSync(filePath, 'utf8');
          
          if (file.endsWith('.json')) {
            this.translations[locale] = JSON.parse(content);
          } else if (file.endsWith('.yaml')) {
            // Simple YAML parsing (for production, use a proper YAML parser)
            const yamlObj = {};
            const lines = content.split('\n');
            let currentSection = yamlObj;
            let sectionStack = [yamlObj];
            let indentStack = [0];
            
            for (const line of lines) {
              const trimmedLine = line.trimEnd();
              if (!trimmedLine || trimmedLine.startsWith('#')) continue;
              
              const indent = line.search(/\S/);
              const keyValueMatch = trimmedLine.match(/^(\s*)([^:]+):\s*(.*)$/);
              
              if (keyValueMatch) {
                const [, , key, value] = keyValueMatch;
                
                // Handle indentation changes
                if (indent > indentStack[indentStack.length - 1]) {
                  // Deeper level
                  if (typeof sectionStack[sectionStack.length - 1] === "string") {
                  const key = sectionStack[sectionStack.length - 1] as string;
                  sectionStack.push(currentSection[key]);
                }
                  indentStack.push(indent);
                } else if (indent < indentStack[indentStack.length - 1]) {
                  // Go back up
                  while (indent < indentStack[indentStack.length - 1]) {
                    sectionStack.pop();
                    indentStack.pop();
                  }
                }
                
                // Set value
                if (value.trim() === '') {
                  currentSection[key.trim()] = {};
                } else {
                  // Remove quotes if present
                  const cleanValue = value.trim().replace(/^['"](.*)['"]$/, '$1');
                  currentSection[key.trim()] = cleanValue;
                }
              }
            }
            
            this.translations[locale] = yamlObj;
          }
        }
      }
    } catch (error) {
      console.error('Error loading translations:', error);
    }
  }

  translate(key: string, locale: string = this.defaultLocale, params: Record<string, any> = {}): string {
    const keys = key.split('.');
    const language = this.translations[locale] || this.translations[this.defaultLocale] || {};
    
    // Navigate through the keys
    let result = language;
    for (const k of keys) {
      result = result?.[k];
      if (result === undefined) break;
    }
    
    if (typeof result !== 'string') {
      // Try default locale if not found
      if (locale !== this.defaultLocale) {
        return this.translate(key, this.defaultLocale, params);
      }
      return key; // Fallback to key
    }
    
    // Replace parameters
    return result.replace(/\{(\w+)\}/g, (_, param) => {
      return params[param] !== undefined ? params[param] : `{${param}}`;
    });
  }

  // Alias for translate
  t(key: string, locale: string = this.defaultLocale, params: Record<string, any> = {}): string {
    return this.translate(key, locale, params);
  }

  getAvailableLocales(): string[] {
    return Object.keys(this.translations);
  }
}
