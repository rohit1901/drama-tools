import { Command } from 'commander';
import * as path from 'path';
import { resolveConfigDir } from '../lib/config';
import { readOpencodeJson, isRtkInstalled } from '../lib/rtk';
import { isCavemanInstalled } from '../lib/caveman';

export function makeExportCommand(): Command {
  return new Command('export')
    .description('Show the current installation status of RTK and Caveman in OpenCode config')
    .option('--dir <path>', 'Override the OpenCode config directory')
    .action((opts: { dir?: string }) => {
      const configDir = resolveConfigDir(opts.dir);
      const config = readOpencodeJson(configDir);

      console.log(`\n  OpenCode config dir: ${configDir}`);
      console.log(`  opencode.json path:  ${path.join(configDir, 'opencode.json')}\n`);

      // RTK status
      if (isRtkInstalled(config)) {
        console.log('  ✓ RTK     installed (present in opencode.json plugins)');
        const pluginCfg = config.pluginConfig as Record<string, unknown> | undefined;
        if (pluginCfg?.['@opencode/plugin-rtk']) {
          console.log('           pluginConfig present');
        }
      } else {
        console.log('  ✗ RTK     not installed');
      }

      // Caveman status
      if (isCavemanInstalled(configDir)) {
        console.log('  ✓ Caveman installed (skills/caveman.md present)');
      } else {
        console.log('  ✗ Caveman not installed');
      }

      console.log('');
      console.log('  Run `opencode-manager install` to install missing tools.');
      console.log('');
    });
}
