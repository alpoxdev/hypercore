import path from 'path';
import { fileURLToPath } from 'url';
import { validateTemplateName } from '../../shared/validators/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * 템플릿 디렉토리 경로 반환
 * dist/index.js -> templates/ (tsup bundles everything into one file)
 */
export const getTemplatesDir = (): string => {
  return path.resolve(__dirname, '../templates');
};

/**
 * 특정 템플릿 경로 반환
 */
export const getTemplatePath = (template: string): string => {
  validateTemplateName(template);
  return path.join(getTemplatesDir(), template);
};
