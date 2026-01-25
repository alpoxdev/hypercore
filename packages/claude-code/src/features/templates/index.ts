/**
 * Templates Feature - Public API
 */

// Path Resolver
export { getTemplatesDir, getTemplatePath } from './template-path-resolver.js';

// Installer
export {
  copySingleTemplate,
  copyMultipleTemplates,
} from './template-installer.js';

// Metadata
export {
  templateMetadata,
  generateIndexClaudeMd,
} from './template-metadata.js';

// Discovery
export {
  listAvailableTemplates,
  checkExistingFiles,
} from './template-discovery.js';
