import { Record } from 'immutable';

import renderer from 'react-test-renderer';

import AvatarOverlayIcon from '../avatar_overlay_icon';

const AccountRecord = Record({
  id: '1',
  acct: 'alice',
  avatar: '/animated/alice.gif',
  avatar_static: '/static/alice.jpg',
});

describe('<AvatarOverlayIcon />', () => {
  const account = new AccountRecord();

  it('directのときAlternateEmailアイコンと静止画avatarが表示される', () => {
    const tree = renderer.create(<AvatarOverlayIcon account={account} visibility='direct' animate={false} />).toJSON();
    expect(tree).toMatchSnapshot();
    expect(JSON.stringify(tree)).toContain('/static/alice.jpg');
  });

  it('privateのときLockアイコンが表示される', () => {
    const tree = renderer.create(<AvatarOverlayIcon account={account} visibility='private' animate={false} />).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('unlistedのときQuietTimeアイコンが表示される', () => {
    const tree = renderer.create(<AvatarOverlayIcon account={account} visibility='unlisted' animate={false} />).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('animate=trueでアニメーションavatarが表示される', () => {
    const tree = renderer.create(<AvatarOverlayIcon account={account} visibility='direct' animate />).toJSON();
    expect(tree).toMatchSnapshot();
    expect(JSON.stringify(tree)).toContain('/animated/alice.gif');
  });
});
