import { sniffImage } from './users.service';

describe('sniffImage', () => {
  it('accepts jpeg, png and webp magic bytes', () => {
    const jpeg = Buffer.from([0xff, 0xd8, 0xff, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    const png = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0, 0, 0, 0, 0, 0, 0, 0]);
    const webp = Buffer.from('RIFF....WEBP');
    expect(sniffImage(jpeg)).toBe('jpg');
    expect(sniffImage(png)).toBe('png');
    expect(sniffImage(webp)).toBe('webp');
  });

  it('rejects empty and unknown bytes', () => {
    expect(sniffImage(Buffer.from('not-an-image!!'))).toBeNull();
    expect(sniffImage(Buffer.from([1, 2, 3]))).toBeNull();
  });
});
