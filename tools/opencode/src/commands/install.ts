import { Command } from 'commander';
import { resolveConfigDir } from '../lib/config';
import { installRtk } from '../lib/rtk';
import { installCaveman } from '../lib/caveman';

export function makeInstallCommand(): Command {
  return new Command('install')
    .description('Install RTK plugin and Caveman skill into OpenCode config')
    .option('--dir <path>', 'Override the OpenCode config directory')
    .option('--rtk-only', 'Install only the RTK plugin')
    .option('--caveman-only', 'Install only the Caveman skill')
    .action((opts: { dir?: string; rtkOnly?: boolean; cavemanOnly?: boolean }) => {
      const configDir = resolveConfigDir(opts.dir);

      console.log(`\n  OpenCode config dir: ${configDir}\n`);

      const installRtkFlag = !opts.cavemanOnly;
      const installCavemanFlag = !opts.rtkOnly;

      if (installRtkFlag) {
        const { alreadyInstalled } = installRtk(configDir);
        if (alreadyInstalled) {
          console.log('  ✓ RTK     already installed in opencode.json — skipping');
        } else {
          console.log('  ✓ RTK     plugin entry added to opencode.json');
        }
      }

      if (installCavemanFlag) {
        const { alreadyInstalled } = installCaveman(configDir);
        if (alreadyInstalled) {
          console.log('  ✓ Caveman already installed in skills/ — skipping');
        } else {
          console.log('  ✓ Caveman caveman.md copied to skills/');
        }
      }

      console.log('\n  Done. Restart OpenCode to pick up changes.\n');
    });
}
