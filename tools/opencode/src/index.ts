#!/usr/bin/env node
import { Command } from 'commander';
import { makeInstallCommand } from './commands/install';
import { makeExportCommand } from './commands/export';

const program = new Command();

program
  .name('opencode-manager')
  .description(
    'CLI tool to install and manage RTK (plugin) and Caveman (skill) for OpenCode.\n' +
    '\n' +
    'Config directory resolution order:\n' +
    '  1. OPENCODE_CONFIG_DIR environment variable\n' +
    '  2. --dir flag\n' +
    '  3. ~/.config/opencode  (default)'
  )
  .version('1.0.0');

program.addCommand(makeInstallCommand());
program.addCommand(makeExportCommand());

program.parse(process.argv);
