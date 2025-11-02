import PropTypes from 'prop-types';
import React from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import { List as ImmutableList } from 'immutable';
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

class FavouriteTags extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    visible: PropTypes.bool.isRequired,
    tags: ImmutablePropTypes.list.isRequired,
    refreshFavouriteTags: PropTypes.func.isRequired,
    onToggle: PropTypes.func.isRequired,
    onLockTag: PropTypes.func.isRequired,
  };

  state = {
    lockedTag: ImmutableList(),
    lockedVisibility: ImmutableList(),
  };

  componentDidMount () {
    this.props.refreshFavouriteTags();
  }

  UNSAFE_componentWillUpdate (nextProps, nextState) {
    // タグ操作に変更があった場合
    if (!this.state.lockedTag.equals(nextState.lockedTag)) {
      const icon = visibilityIcons.concat().reverse().find(icon => nextState.lockedVisibility.includes(icon.key));
      this.execLockTag(
        nextState.lockedTag.join(' '),
        typeof icon === 'undefined' ? '' : icon.key,
      );
    }
  }

  execLockTag (tag, icon) {
    this.props.onLockTag(tag, icon);
  }

  handleLockTag (tag, visibility) {
    const tagName = `#${tag}`;
    return ((e) => {
      e.preventDefault();
      if (this.state.lockedTag.includes(tagName)) {
        this.setState({ lockedTag: this.state.lockedTag.delete(this.state.lockedTag.indexOf(tagName)) });
        this.setState({ lockedVisibility: this.state.lockedVisibility.delete(this.state.lockedTag.indexOf(tagName)) });
      } else {
        this.setState({ lockedTag: this.state.lockedTag.push(tagName) });
        this.setState({ lockedVisibility: this.state.lockedVisibility.push(visibility) });
      }
    }).bind(this);
  }

  visibilityToIcon (val) {
    return visibilityIcons.find(icon => icon.key === val).icon;
  }

  render () {
    const { intl, visible, onToggle } = this.props;

    const lockIcon = (tag) => {
      const isLocked = this.state.lockedTag.includes(`#${tag.get('name')}`);
      const icon = isLocked ? lockIcons.lock : lockIcons.unlock;
      return <Icon id={icon.id} icon={icon} className='favourite-tags__lock' />;
    };

    const tags = this.props.tags.map(tag => (
      <li key={tag.get('name')}>
        <Icon id={tag.get('visibility')} icon={this.visibilityToIcon(tag.get('visibility'))} className='favourite-tags__icon' />
        <Link
          to={`/timelines/tag/${tag.get('name')}`}
          className='compose__extra__body__name'
          key={tag.get('name')}
        >
          {`#${tag.get('name')}`}
        </Link>
        <button onClick={this.handleLockTag(tag.get('name'), tag.get('visibility'))} className='favourite-tags__lock' >
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
        <Foldable isVisible={visible} fullHeight={this.props.tags.size * 30} minHeight={0} >
          <ul className='compose__extra__body'>
            {tags}
          </ul>
        </Foldable>
      </div>
    );
  }

}

export default injectIntl(FavouriteTags);
