import { useCallback, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import type Immutable from 'immutable';

import { PlusIcon, TagIcon } from '@phosphor-icons/react';

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
  MenuItemLink,
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
        {tags.isEmpty() && <FavouriteTagsEmpty />}
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

// 普段のメニューはロックの切り替えに専念させ、設定画面への常設の入口はアカウントカードの「⋯」メニューに置く。
// 空のときだけは行き止まりにならないよう、ここから登録画面へ誘導する
const FavouriteTagsEmpty: React.FC = () => (
  <>
    <p className='favourite-tags__empty'>
      <FormattedMessage
        id='compose_form.favourite_tags.empty'
        defaultMessage='No favourite tags yet.'
      />
    </p>
    <MenuItemLink as='a' href='/settings/favourite_tags' icon={PlusIcon}>
      <FormattedMessage
        id='compose_form.favourite_tags.register'
        defaultMessage='Register favourite tags'
      />
    </MenuItemLink>
  </>
);

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
