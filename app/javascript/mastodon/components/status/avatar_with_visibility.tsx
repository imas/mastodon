import type { StatusVisibility } from '@/mastodon/api_types/statuses';
import type { AccountStatusShape } from '@/mastodon/models/status';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';

import { Avatar } from '../avatar';
import { Icon } from '../icon';

const icons: Partial<Record<StatusVisibility, typeof LockIcon>> = {
  unlisted: QuietTimeIcon,
  private: LockIcon,
  direct: AlternateEmailIcon,
};

// imastodon: 公開範囲が public 以外の投稿はアバターに公開範囲アイコンを重ねる（旧ヘッダーの AvatarOverlayIcon と同じ見た目）
export const AvatarWithVisibility: React.FC<{
  account: AccountStatusShape['account'];
  visibility: StatusVisibility;
}> = ({ account, visibility }) => {
  const icon = icons[visibility];

  if (!icon) {
    return <Avatar account={account} size={null} />;
  }

  return (
    <span className='account__avatar-overlay status__avatar-with-visibility'>
      <Avatar account={account} size={null} />
      <span className='account__avatar-overlay-overlay'>
        <Icon
          id={visibility}
          icon={icon}
          className='account__avatar-overlay-icon-overlay'
        />
      </span>
    </span>
  );
};
