import { fromJS } from 'immutable';

import renderer from 'react-test-renderer';

import AvatarOverlayIcon from '../avatar_overlay_icon';

describe('<AvatarOverlayIcon>', () => {
  const account = fromJS({
    username: 'alice',
    acct: 'alice',
    display_name: 'Alice',
    avatar: '/animated/alice.gif',
    avatar_static: '/static/alice.jpg',
  });

  const findByClassName = (node, className) => {
    if (!node || typeof node === 'string') return null;
    if (node.props?.className?.split?.(' ').includes(className)) return node;
    if (!node.children) return null;
    for (const child of node.children) {
      const found = findByClassName(child, className);
      if (found) return found;
    }
    return null;
  };

  it('size プロパティをコンテナとアバター画像のスタイルに反映する', () => {
    const tree = renderer.create(
      <AvatarOverlayIcon account={account} visibility='direct' size={40} />
    ).toJSON();

    const overlay = findByClassName(tree, 'account__avatar-overlay');
    expect(overlay.props.style).toMatchObject({ width: 40, height: 40 });

    const base = findByClassName(tree, 'account__avatar-overlay-icon-base');
    expect(base.props.style).toMatchObject({ width: 40, height: 40 });
  });
});
