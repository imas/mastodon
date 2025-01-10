import PropTypes from 'prop-types';
import React from 'react';

import { defineMessages, injectIntl } from 'react-intl';

import Button from '../../../components/button';


const messages = defineMessages({
  add_favourite_tags_public: { id: 'tag.add_favourite.public', defaultMessage: 'add in the favourite tags (Public)' },
  add_favourite_tags_unlisted: { id: 'tag.add_favourite.unlisted', defaultMessage: 'add in the favourite tags (Unlisted)' },
  remove_favourite_tags_public: { id: 'tag.remove_favourite.public', defaultMessage: 'Remove from the favourite tags (Public)' },
  remove_favourite_tags_unlisted: { id: 'tag.remove_favourite.unlisted', defaultMessage: 'Remove from the favourite tags (Unlisted)' },
});

class FavouriteToggle extends React.PureComponent {

  static propTypes = {
    tag: PropTypes.string.isRequired,
    addFavouriteTags: PropTypes.func.isRequired,
    removeFavouriteTags: PropTypes.func.isRequired,
    unlistedId: PropTypes.number,
    publicId: PropTypes.number,
    intl: PropTypes.object.isRequired,
  };

  addFavouriteTags = (visibility) => {
    this.props.addFavouriteTags(this.props.tag, visibility);
  };

  addPublic = () => {
    this.addFavouriteTags('public');
  };

  addUnlisted = () => {
    this.addFavouriteTags('unlisted');
  };

  removeFavouriteTags = (id) => {
    this.props.removeFavouriteTags(id);
  };

  removePublic = () => {
    this.removeFavouriteTags(this.props.publicId);
  };

  removeUnlisted = () => {
    this.removeFavouriteTags(this.props.unlistedId);
  };

  render () {
    const { intl, unlistedId, publicId } = this.props;

    return (
      <div>
        <div className='column-settings__row'>
          {
            publicId != null ? <Button className='favourite-tags__remove-button-in-column' text={intl.formatMessage(messages.remove_favourite_tags_public)} onClick={this.removePublic} block />
              : <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_public)} onClick={this.addPublic} block />
          }
          {
            unlistedId != null ? <Button className='favourite-tags__remove-button-in-column' text={intl.formatMessage(messages.remove_favourite_tags_unlisted)} onClick={this.removeUnlisted} block />
              : <Button className='favourite-tags__add-button-in-column' text={intl.formatMessage(messages.add_favourite_tags_unlisted)} onClick={this.addUnlisted} block />
          }
        </div>
      </div>
    );
  }

}

export default injectIntl(FavouriteToggle)
