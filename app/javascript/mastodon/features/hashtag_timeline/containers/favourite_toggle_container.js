import { connect } from 'react-redux';

import { addFavouriteTags, removeFavouriteTags } from '../../../actions/favourite_tags';
import FavouriteToggle from '../components/favourite_toggle';

const mapStateToProps = (state, { tag }) => ({
  publicId: state.getIn(['favourite_tags', 'tags']).find(t => t.get('name') === tag && t.get('visibility') === 'public')?.get('id'),
  unlistedId: state.getIn(['favourite_tags', 'tags']).find(t => t.get('name') === tag && t.get('visibility') === 'unlisted')?.get('id'),
});

const mapDispatchToProps = dispatch => ({

  addFavouriteTags (tag, visibility) {
    dispatch(addFavouriteTags(tag, visibility));
  },

  removeFavouriteTags (id) {
    dispatch(removeFavouriteTags(id));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(FavouriteToggle);
