import { memo, useCallback } from 'react';

import PropTypes from 'prop-types';
import { defineMessages, useIntl } from 'react-intl';

import { Button } from '../../../components/button';

const messages = defineMessages({
  add_favourite_tags_public: { id: 'tag.add_favourite.public', defaultMessage: 'add in the favourite tags (Public)' },
  add_favourite_tags_unlisted: { id: 'tag.add_favourite.unlisted', defaultMessage: 'add in the favourite tags (Unlisted)' },
  remove_favourite_tags_public: { id: 'tag.remove_favourite.public', defaultMessage: 'Remove from the favourite tags (Public)' },
  remove_favourite_tags_unlisted: { id: 'tag.remove_favourite.unlisted', defaultMessage: 'Remove from the favourite tags (Unlisted)' },
});

const FavouriteToggle = ({ tag, addFavouriteTags, removeFavouriteTags, unlistedId, publicId }) => {
  const intl = useIntl();

  const addPublic = useCallback(() => {
    addFavouriteTags(tag, 'public');
  }, [addFavouriteTags, tag]);

  const addUnlisted = useCallback(() => {
    addFavouriteTags(tag, 'unlisted');
  }, [addFavouriteTags, tag]);

  const removePublic = useCallback(() => {
    removeFavouriteTags(publicId);
  }, [removeFavouriteTags, publicId]);

  const removeUnlisted = useCallback(() => {
    removeFavouriteTags(unlistedId);
  }, [removeFavouriteTags, unlistedId]);

  return (
    <div>
      <div className='column-settings__row'>
        {
          publicId != null ? <Button className='favourite-tags__remove-button-in-column' text={intl.formatMessage(messages.remove_favourite_tags_public)} onClick={removePublic} block />
            : <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_public)} onClick={addPublic} block />
        }
        {
          unlistedId != null ? <Button className='favourite-tags__remove-button-in-column' text={intl.formatMessage(messages.remove_favourite_tags_unlisted)} onClick={removeUnlisted} block />
            : <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_unlisted)} onClick={addUnlisted} block />
        }
      </div>
    </div>
  );
};

FavouriteToggle.propTypes = {
  tag: PropTypes.string.isRequired,
  addFavouriteTags: PropTypes.func.isRequired,
  removeFavouriteTags: PropTypes.func.isRequired,
  unlistedId: PropTypes.number,
  publicId: PropTypes.number,
};

export default memo(FavouriteToggle);
