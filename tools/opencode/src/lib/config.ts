import * as os from 'os';
import * as path from 'path';

/**
 * Resolves the OpenCode config directory.
 * Priority: OPENCODE_CONFIG_DIR env var > --dir flag > ~/.config/opencode
 */
export function resolveConfigDir(dirFlag?: string): string {
  if (process.env.OPENCODE_CONFIG_DIR) {
    return process.env.OPENCODE_CONFIG_DIR;
  }
  if (dirFlag) {
    return dirFlag;
  }
  return path.join(os.homedir(), '.config', 'opencode');
}

export const OPENCODE_JSON = 'opencode.json';
export const SKILLS_DIR = 'skills';
export const RTK_PLUGIN_NAME = '@opencode/plugin-rtk';
export const CAVEMAN_SKILL_FILE = 'caveman.md';
