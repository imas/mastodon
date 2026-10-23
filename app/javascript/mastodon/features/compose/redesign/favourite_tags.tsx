import { useCallback, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import type Immutable from 'immutable';

import { TagIcon } from '@phosphor-icons/react';

import {
  refreshFavouriteTags,
  toggleLockFavouriteTag,
} from '@/mastodon/actions/favourite_tags';
import { Button, CaretIcon } from '@/mastodon/components/button/redesign';
import {
  Menu,
  MenuList,
  MenuTrigger,
  MenuItemCheckbox,
} from '@/mastodon/components/menu';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

type FavouriteTag = Immutable.Map<string, unknown>;

export const ComposeFavouriteTags: React.FC = () => {
  const dispatch = useAppDispatch();
  const tags = useAppSelector(
    (state) => state.favourite_tags.get('tags') as Immutable.List<FavouriteTag>,
  );
  const lockedTags = useAppSelector(
    (state) =>
      state.favourite_tags.get('lockedTags') as Immutable.List<FavouriteTag>,
  );

  // お気に入りタグ一覧は旧 UI の投稿欄が読み込んでいた。リデザイン版ではそれが描画されないので、ここで読み込む
  useEffect(() => {
    dispatch(refreshFavouriteTags());
  }, [dispatch]);

  const isLocked = (tag: FavouriteTag) =>
    lockedTags.some((locked) => locked.get('name') === tag.get('name'));

  return (
    <Menu>
      <MenuTrigger
        as={Button}
        size='sm'
        leadingIcon={TagIcon}
        trailingIcon={CaretIcon}
      >
        <FormattedMessage
          id='compose_form.favourite_tags'
          defaultMessage='Favourite tags'
        />
        {lockedTags.size > 0 && `(${lockedTags.size})`}
      </MenuTrigger>
      <MenuList placement='bottom-start'>
        {tags.map((tag) => (
          <FavouriteTagItem
            key={tag.get('id') as number}
            name={tag.get('name') as string}
            visibility={tag.get('visibility') as string}
            checked={isLocked(tag)}
          />
        ))}
      </MenuList>
    </Menu>
  );
};

const FavouriteTagItem: React.FC<{
  name: string;
  visibility: string;
  checked: boolean;
}> = ({ name, visibility, checked }) => {
  const dispatch = useAppDispatch();
  const handleChange = useCallback(() => {
    dispatch(toggleLockFavouriteTag(name, visibility));
  }, [dispatch, name, visibility]);

  return (
    <MenuItemCheckbox
      value={name}
      checked={checked}
      onChange={handleChange}
      keepMenuOpenOnClick
    >
      #{name}
    </MenuItemCheckbox>
  );
};
