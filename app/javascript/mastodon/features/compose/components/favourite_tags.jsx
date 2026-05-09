import { memo, useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, useIntl } from 'react-intl';

import { List as ImmutableList } from 'immutable';

import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

import Link from 'react-router-dom/Link';

import { Icon } from '@/mastodon/components/icon';
import EditNoteIcon from '@/material-icons/400-24px/edit_note.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';
import TagIcon from '@/material-icons/400-24px/sell-fill.svg?react';
import SettingIcon from '@/material-icons/400-24px/settings-fill.svg?react';

import FoldButton from '../../../components/fold_button';
import Foldable from '../../../components/foldable';

const messages = defineMessages({
  favourite_tags: { id: 'compose_form.favourite_tags', defaultMessage: 'Favourite tags' },
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

const visibilityIcons = [
  { key: 'public', icon: PublicIcon },
  { key: 'unlisted', icon: QuietTimeIcon },
  { key: 'private', icon: LockIcon },
];

const lockIcons = {
  lock: LockIcon,
  unlock: EditNoteIcon,
};

const visibilityToIcon = (val) => visibilityIcons.find(icon => icon.key === val).icon;

const FavouriteTags = ({ visible, tags, refreshFavouriteTags, onToggle, onLockTag }) => {
  const intl = useIntl();
  const [lockedTag, setLockedTag] = useState(ImmutableList());
  const [lockedVisibility, setLockedVisibility] = useState(ImmutableList());
  const isFirstUpdate = useRef(true);

  useEffect(() => {
    refreshFavouriteTags();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // UNSAFE_componentWillUpdate相当: lockedTag変化時にonLockTagを呼ぶ
  useEffect(() => {
    if (isFirstUpdate.current) {
      isFirstUpdate.current = false;
      return;
    }
    const icon = visibilityIcons.concat().reverse().find(i => lockedVisibility.includes(i.key));
    onLockTag(
      lockedTag.join(' '),
      typeof icon === 'undefined' ? '' : icon.key,
    );
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lockedTag]);

  const handleLockTag = useCallback((tag, visibility) => {
    const tagName = `#${tag}`;
    return (e) => {
      e.preventDefault();
      if (lockedTag.includes(tagName)) {
        const idx = lockedTag.indexOf(tagName);
        setLockedTag(lockedTag.delete(idx));
        setLockedVisibility(lockedVisibility.delete(idx));
      } else {
        setLockedTag(lockedTag.push(tagName));
        setLockedVisibility(lockedVisibility.push(visibility));
      }
    };
  }, [lockedTag, lockedVisibility]);

  const lockIcon = (tag) => {
    const isLocked = lockedTag.includes(`#${tag.get('name')}`);
    const icon = isLocked ? lockIcons.lock : lockIcons.unlock;
    return <Icon id={icon.id} icon={icon} className='favourite-tags__lock' />;
  };

  const renderedTags = tags.map(tag => (
    <li key={tag.get('id')}>
      <Icon id={tag.get('visibility')} icon={visibilityToIcon(tag.get('visibility'))} className='favourite-tags__icon' />
      <Link
        to={`/timelines/tag/${tag.get('name')}`}
        className='compose__extra__body__name'
      >
        {`#${tag.get('name')}`}
      </Link>
      <button onClick={handleLockTag(tag.get('name'), tag.get('visibility'))} className='favourite-tags__lock' >
        {lockIcon(tag)}
      </button>
    </li>
  ));

  return (
    <div className='compose__extra'>
      <div className='compose__extra__header'>
        <div className='compose__extra__header__left'>
          <Icon id={'tag_icon'} icon={TagIcon} className='compose__extra__header__icon' />
          <span>{intl.formatMessage(messages.favourite_tags)}</span>
        </div>
        <div className='compose__extra__header__right'>
          <a href='/settings/favourite_tags' className='compose__extra__header__icon'>
            <Icon id='setting_icon' icon={SettingIcon} className='compose__extra__header__icon' />
          </a>
          <div className='compose__extra__header__fold__icon'>
            <FoldButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={onToggle} size={20} animate active={visible} />
          </div>
        </div>
      </div>
      <Foldable isVisible={visible}>
        <ul className='compose__extra__body'>
          {renderedTags}
        </ul>
      </Foldable>
    </div>
  );
};

FavouriteTags.propTypes = {
  visible: PropTypes.bool.isRequired,
  tags: ImmutablePropTypes.list.isRequired,
  refreshFavouriteTags: PropTypes.func.isRequired,
  onToggle: PropTypes.func.isRequired,
  onLockTag: PropTypes.func.isRequired,
};

export default memo(FavouriteTags);
