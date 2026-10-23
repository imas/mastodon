import { useCallback, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import type Immutable from 'immutable';

import {
  addFavouriteTags,
  refreshFavouriteTags,
  removeFavouriteTags,
} from '@/mastodon/actions/favourite_tags';
import { MenuItem } from '@/mastodon/components/menu';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';

type FavouriteTagVisibility = 'public' | 'unlisted';

const useFavouriteTagId = (
  tagName: string,
  visibility: FavouriteTagVisibility,
) =>
  useAppSelector((state) => {
    const tags = state.favourite_tags.get('tags') as Immutable.List<
      Immutable.Map<string, unknown>
    >;
    return tags
      .find(
        (tag) =>
          tag.get('name') === tagName && tag.get('visibility') === visibility,
      )
      ?.get('id') as number | undefined;
  });

const FavouriteTagMenuItem: React.FC<{
  tagName: string;
  visibility: FavouriteTagVisibility;
  addLabel: React.ReactNode;
  removeLabel: React.ReactNode;
}> = ({ tagName, visibility, addLabel, removeLabel }) => {
  const dispatch = useAppDispatch();
  const favouriteTagId = useFavouriteTagId(tagName, visibility);

  const handleClick = useCallback(() => {
    if (favouriteTagId === undefined) {
      dispatch(addFavouriteTags(tagName, visibility));
    } else {
      dispatch(removeFavouriteTags(favouriteTagId));
    }
  }, [dispatch, favouriteTagId, tagName, visibility]);

  return (
    <MenuItem onClick={handleClick}>
      {favouriteTagId === undefined ? addLabel : removeLabel}
    </MenuItem>
  );
};

export const FavouriteTagMenuItems: React.FC<{ tagName: string }> = ({
  tagName,
}) => {
  const dispatch = useAppDispatch();

  // お気に入りタグ一覧は旧 UI の投稿欄が読み込んでいた。リデザイン版ではそれが描画されないので、ここで読み込む
  useEffect(() => {
    dispatch(refreshFavouriteTags());
  }, [dispatch]);

  return (
    <>
      <FavouriteTagMenuItem
        tagName={tagName}
        visibility='public'
        addLabel={
          <FormattedMessage
            id='tag.add_favourite.public'
            defaultMessage='add in the favourite tags (Public)'
          />
        }
        removeLabel={
          <FormattedMessage
            id='tag.remove_favourite.public'
            defaultMessage='Remove from the favourite tags (Public)'
          />
        }
      />
      <FavouriteTagMenuItem
        tagName={tagName}
        visibility='unlisted'
        addLabel={
          <FormattedMessage
            id='tag.add_favourite.unlisted'
            defaultMessage='add in the favourite tags (Unlisted)'
          />
        }
        removeLabel={
          <FormattedMessage
            id='tag.remove_favourite.unlisted'
            defaultMessage='Remove from the favourite tags (Unlisted)'
          />
        }
      />
    </>
  );
};
