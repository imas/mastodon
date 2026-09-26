import en from './en.json';
import jaIM from './ja-IM.json';
import ja from './ja.json';

async function loadMessages(lang: string) {
  vi.resetModules();
  document.documentElement.lang = lang;

  const { loadLocale } = await import('./load_locale');
  const { getLocale } = await import('./global_locale');
  await loadLocale();

  return getLocale().messages;
}

describe('loadLocale', () => {
  describe('ja-IM のとき', () => {
    it('ja-IM で言い換えているキーは ja-IM の訳文になる', async () => {
      const key = 'compose_form.publish';
      expect(jaIM[key]).not.toBe(ja[key]);

      const messages = await loadMessages('ja-IM');

      expect(messages[key]).toBe(jaIM[key]);
    });

    it('ja-IM に無いキーは ja の訳文になる', async () => {
      const key = 'about.contact';
      expect(jaIM).not.toHaveProperty(key);

      const messages = await loadMessages('ja-IM');

      expect(messages[key]).toBe(ja[key]);
    });
  });

  describe('ja のとき', () => {
    it('ja-IM の訳文が混ざらない', async () => {
      const messages = await loadMessages('ja');

      expect(messages).toEqual(ja);
    });
  });
});

describe('ja-IM.json', () => {
  it('en.json に存在しないキーを持たない', () => {
    const unknownKeys = Object.keys(jaIM).filter((key) => !(key in en));

    expect(unknownKeys).toEqual([]);
  });

  it.todo('ja.json と同じ訳文のキーを持たない');
});
