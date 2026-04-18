import * as fs from 'fs';
import * as path from 'path';
import { SKILLS_DIR, CAVEMAN_SKILL_FILE } from './config';

// Resolve the bundled caveman.md asset shipped alongside this CLI.
const ASSET_PATH = path.resolve(__dirname, '..', '..', 'assets', CAVEMAN_SKILL_FILE);

/**
 * Returns the target path for caveman.md inside the OpenCode config dir.
 */
export function cavemanTargetPath(configDir: string): string {
  return path.join(configDir, SKILLS_DIR, CAVEMAN_SKILL_FILE);
}

/**
 * Returns true if caveman.md is already present in the skills dir.
 */
export function isCavemanInstalled(configDir: string): boolean {
  return fs.existsSync(cavemanTargetPath(configDir));
}

/**
 * Copies the bundled caveman.md skill file into ~/.config/opencode/skills/.
 * Creates the skills directory if needed. Idempotent.
 */
export function installCaveman(configDir: string): { alreadyInstalled: boolean } {
  if (isCavemanInstalled(configDir)) {
    return { alreadyInstalled: true };
  }

  const skillsDir = path.join(configDir, SKILLS_DIR);
  fs.mkdirSync(skillsDir, { recursive: true });

  const dest = cavemanTargetPath(configDir);
  fs.copyFileSync(ASSET_PATH, dest);

  return { alreadyInstalled: false };
}

/**
 * Removes caveman.md from the skills dir.
 * Returns false if it was not present.
 */
export function uninstallCaveman(configDir: string): { wasInstalled: boolean } {
  const dest = cavemanTargetPath(configDir);
  if (!fs.existsSync(dest)) {
    return { wasInstalled: false };
  }
  fs.rmSync(dest);
  return { wasInstalled: true };
}

/**
 * Reads the content of the installed caveman.md for export.
 */
export function exportCaveman(configDir: string): string | null {
  const dest = cavemanTargetPath(configDir);
  if (!fs.existsSync(dest)) {
    return null;
  }
  return fs.readFileSync(dest, 'utf-8');
}
