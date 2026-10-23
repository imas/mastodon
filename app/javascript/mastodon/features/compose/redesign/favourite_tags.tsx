import { useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import type Immutable from 'immutable';

import { TagIcon } from '@phosphor-icons/react';

import { refreshFavouriteTags } from '@/mastodon/actions/favourite_tags';
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

  // お気に入りタグ一覧は旧 UI の投稿欄が読み込んでいた。リデザイン版ではそれが描画されないので、ここで読み込む
  useEffect(() => {
    dispatch(refreshFavouriteTags());
  }, [dispatch]);

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
      </MenuTrigger>
      <MenuList placement='bottom-start'>
        {tags.map((tag) => (
          <MenuItemCheckbox
            key={tag.get('id') as number}
            value={tag.get('name') as string}
            checked={false}
            keepMenuOpenOnClick
          >
            #{tag.get('name') as string}
          </MenuItemCheckbox>
        ))}
      </MenuList>
    </Menu>
  );
};
