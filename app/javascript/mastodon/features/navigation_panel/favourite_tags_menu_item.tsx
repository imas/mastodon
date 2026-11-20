import { FormattedMessage } from 'react-intl';

import { TagIcon } from '@phosphor-icons/react';

import { MenuItemLink } from '@/mastodon/components/menu';

// imastodon: お気に入りタグの設定画面への常設の入口。upstream の「設定」と同じく別タブで開く
export const FavouriteTagsMenuItemLink: React.FC = () => (
  <MenuItemLink as='a' href='/settings/favourite_tags' icon={TagIcon}>
    <FormattedMessage
      id='navigation_bar.favourite_tags'
      defaultMessage='Favourite tags'
    />
  </MenuItemLink>
);
