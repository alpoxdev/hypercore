import path from 'path';

/**
 * 템플릿 이름 검증 (Path Traversal 방지)
 */
export const validateTemplateName = (template: string): void => {
  // 경로 분리자 및 상위 경로 참조 차단
  const sanitized = path.basename(template);
  if (sanitized !== template || template.includes('..')) {
    throw new Error(`Invalid template name: "${template}"`);
  }
};

/**
 * 대상 디렉토리 검증 (시스템 경로 보호)
 */
export const validateTargetDir = (targetDir: string): void => {
  const resolved = path.resolve(targetDir);

  // 시스템 경로 보호 (Unix/Linux/macOS)
  const protectedPaths = [
    '/',
    '/usr',
    '/etc',
    '/bin',
    '/sbin',
    '/home',
    '/var',
    '/root',
  ];

  // Windows 보호 경로
  if (process.platform === 'win32') {
    const winProtected = [
      'C:\\Windows',
      'C:\\Program Files',
      'C:\\Program Files (x86)',
    ];
    protectedPaths.push(...winProtected);
  }

  for (const protectedPath of protectedPaths) {
    if (
      resolved === protectedPath ||
      resolved.startsWith(protectedPath + path.sep)
    ) {
      throw new Error(`Cannot modify protected system path: ${resolved}`);
    }
  }
};
