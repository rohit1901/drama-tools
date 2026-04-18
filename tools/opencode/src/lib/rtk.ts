import * as fs from 'fs';
import * as path from 'path';
import { OPENCODE_JSON, RTK_PLUGIN_NAME } from './config';

export interface OpencodeJson {
  plugins?: string[];
  pluginConfig?: Record<string, unknown>;
  [key: string]: unknown;
}

/**
 * Reads opencode.json or returns empty object if it does not exist.
 */
export function readOpencodeJson(configDir: string): OpencodeJson {
  const filePath = path.join(configDir, OPENCODE_JSON);
  if (!fs.existsSync(filePath)) {
    return {};
  }
  const raw = fs.readFileSync(filePath, 'utf-8');
  try {
    return JSON.parse(raw) as OpencodeJson;
  } catch {
    throw new Error(`Failed to parse ${filePath}: invalid JSON`);
  }
}

/**
 * Writes opencode.json to the config dir (pretty-printed, 2-space indent).
 */
export function writeOpencodeJson(configDir: string, data: OpencodeJson): void {
  const filePath = path.join(configDir, OPENCODE_JSON);
  fs.mkdirSync(configDir, { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n', 'utf-8');
}

/**
 * Returns true if the RTK plugin is already present in opencode.json.
 */
export function isRtkInstalled(config: OpencodeJson): boolean {
  return Array.isArray(config.plugins) && config.plugins.includes(RTK_PLUGIN_NAME);
}

/**
 * Injects the RTK plugin entry and default pluginConfig into opencode.json.
 * Idempotent - safe to call multiple times.
 */
export function installRtk(configDir: string): { alreadyInstalled: boolean } {
  const config = readOpencodeJson(configDir);

  if (isRtkInstalled(config)) {
    return { alreadyInstalled: true };
  }

  config.plugins = [...(config.plugins ?? []), RTK_PLUGIN_NAME];

  if (!config.pluginConfig) {
    config.pluginConfig = {};
  }

  if (!config.pluginConfig[RTK_PLUGIN_NAME]) {
    config.pluginConfig[RTK_PLUGIN_NAME] = {
      enabled: true,
      commands: [
        'git status',
        'git diff',
        'ls',
        'cat',
        'rg',
        'grep',
        'find',
        'cargo',
        'docker',
        'kubectl',
        'npm test',
      ],
      rewriteMap: {
        cat: 'rtk read',
        rg: 'rtk grep',
        eslint: 'rtk lint',
      },
    };
  }

  writeOpencodeJson(configDir, config);
  return { alreadyInstalled: false };
}

/**
 * Removes the RTK plugin entry from opencode.json.
 * Returns false if it was not present.
 */
export function uninstallRtk(configDir: string): { wasInstalled: boolean } {
  const config = readOpencodeJson(configDir);

  if (!isRtkInstalled(config)) {
    return { wasInstalled: false };
  }

  config.plugins = (config.plugins ?? []).filter((p) => p !== RTK_PLUGIN_NAME);

  if (config.pluginConfig) {
    delete config.pluginConfig[RTK_PLUGIN_NAME];
  }

  writeOpencodeJson(configDir, config);
  return { wasInstalled: true };
}
