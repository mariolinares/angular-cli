/**
 * @license
 * Copyright Google LLC All Rights Reserved.
 *
 * Use of this source code is governed by an MIT-style license that can be
 * found in the LICENSE file at https://angular.io/license
 */

import { normalize } from '@angular-devkit/core';
import { SimpleFileEntry } from './entry';
import { UpdateRecorderBase } from './recorder';

describe('UpdateRecorderBase', () => {
  it('works for simple files', () => {
    const buffer = Buffer.from('Hello World');
    const entry = new SimpleFileEntry(normalize('/some/path'), buffer);

    const recorder = UpdateRecorderBase.createFromFileEntry(entry);
    recorder.insertLeft(5, ' beautiful');
    const result = recorder.apply(buffer);
    expect(result.toString()).toBe('Hello beautiful World');
  });

  it('works for simple files (2)', () => {
    const buffer = Buffer.from('Hello World');
    const entry = new SimpleFileEntry(normalize('/some/path'), buffer);

    const recorder = UpdateRecorderBase.createFromFileEntry(entry);
    recorder.insertRight(5, ' beautiful');
    const result = recorder.apply(buffer);
    expect(result.toString()).toBe('Hello beautiful World');
  });

  it('works with multiple adjacent inserts', () => {
    const buffer = Buffer.from('Hello beautiful World');
    const entry = new SimpleFileEntry(normalize('/some/path'), buffer);

    const recorder = UpdateRecorderBase.createFromFileEntry(entry);
    recorder.remove(6, 9);
    recorder.insertRight(6, 'amazing');
    recorder.insertRight(15, ' and fantastic');
    const result = recorder.apply(buffer);
    expect(result.toString()).toBe('Hello amazing and fantastic World');
  });

  it('can create the proper recorder', () => {
    const e = new SimpleFileEntry(normalize('/some/path'), Buffer.from('hello'));
    expect(UpdateRecorderBase.createFromFileEntry(e) instanceof UpdateRecorderBase).toBe(true);
  });

  it('can create the proper recorder (bom)', () => {
    const eBom = new SimpleFileEntry(normalize('/some/path'), Buffer.from('\uFEFFhello'));
    expect(UpdateRecorderBase.createFromFileEntry(eBom) instanceof UpdateRecorderBase).toBe(true);
  });

  it('supports empty files', () => {
    const e = new SimpleFileEntry(normalize('/some/path'), Buffer.from(''));
    expect(UpdateRecorderBase.createFromFileEntry(e) instanceof UpdateRecorderBase).toBe(true);
  });

  it('supports empty files (bom)', () => {
    const eBom = new SimpleFileEntry(normalize('/some/path'), Buffer.from('\uFEFF'));
    expect(UpdateRecorderBase.createFromFileEntry(eBom) instanceof UpdateRecorderBase).toBe(true);
  });
});

describe('UpdateRecorderBom', () => {
  it('works for simple files', () => {
    const buffer = Buffer.from('\uFEFFHello World');
    const entry = new SimpleFileEntry(normalize('/some/path'), buffer);

    const recorder = UpdateRecorderBase.createFromFileEntry(entry);
    recorder.insertLeft(5, ' beautiful');
    const result = recorder.apply(buffer);
    expect(result.toString()).toBe('\uFEFFHello beautiful World');
  });
});
