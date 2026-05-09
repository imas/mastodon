import { memo } from 'react';

import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';

import { Avatar } from './avatar';
import { Icon } from './icon';

const icons = {
  public: PublicIcon,
  unlisted: QuietTimeIcon,
  private: LockIcon,
  direct: AlternateEmailIcon,
};

const AvatarOverlayIcon = ({ account, visibility, animate, size = 46 }) => (
  <div className='account__avatar-overlay' style={{ width: size, height: size }}>
    <div className='account__avatar-overlay-base'>
      <Avatar account={account} animate={animate} size={size} />
    </div>
    <div className='account__avatar-overlay-overlay'>
      <Icon id={visibility} icon={icons[visibility]} className='account__avatar-overlay-icon-overlay' />
    </div>
  </div>
);

AvatarOverlayIcon.propTypes = {
  account: ImmutablePropTypes.map.isRequired,
  visibility: PropTypes.string.isRequired,
  animate: PropTypes.bool,
  size: PropTypes.number,
};

export default memo(AvatarOverlayIcon);
