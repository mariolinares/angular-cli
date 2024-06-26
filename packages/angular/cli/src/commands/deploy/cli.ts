/**
 * @license
 * Copyright Google LLC All Rights Reserved.
 *
 * Use of this source code is governed by an MIT-style license that can be
 * found in the LICENSE file at https://angular.io/license
 */

import { join } from 'node:path';
import { MissingTargetChoice } from '../../command-builder/architect-base-command-module';
import { ArchitectCommandModule } from '../../command-builder/architect-command-module';
import { CommandModuleImplementation } from '../../command-builder/command-module';

export default class DeployCommandModule
  extends ArchitectCommandModule
  implements CommandModuleImplementation
{
  // The below choices should be kept in sync with the list in https://angular.dev/tools/cli/deployment
  override missingTargetChoices: MissingTargetChoice[] = [
    {
      name: 'Amazon S3',
      value: '@jefiozie/ngx-aws-deploy',
    },
    {
      name: 'Firebase',
      value: '@angular/fire',
    },
    {
      name: 'Netlify',
      value: '@netlify-builder/deploy',
    },
    {
      name: 'GitHub Pages',
      value: 'angular-cli-ghpages',
    },
  ];

  multiTarget = false;
  command = 'deploy [project]';
  longDescriptionPath = join(__dirname, 'long-description.md');
  describe =
    'Invokes the deploy builder for a specified project or for the default project in the workspace.';
}
