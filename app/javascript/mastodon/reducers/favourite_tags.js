import Immutable from 'immutable';

import { FAVOURITE_TAGS_SUCCESS, TOGGLE_FAVOURITE_TAGS, TOGGLE_LOCK_FAVOURITE_TAG } from '../actions/favourite_tags';

const initialState = Immutable.Map({
  tags: Immutable.List(),
  visible: true,
  lockedTags: Immutable.List(),
});

const toggleLock = (lockedTags, name, visibility) => {
  const index = lockedTags.findIndex(tag => tag.get('name') === name);
  return index === -1 ? lockedTags.push(Immutable.Map({ name, visibility })) : lockedTags.delete(index);
};

export default function favourite_tags(state = initialState, action) {
  switch(action.type) {
  case FAVOURITE_TAGS_SUCCESS:
    return state.set('tags', Immutable.fromJS(action.tags));
  case TOGGLE_FAVOURITE_TAGS:
    return state.set('visible', !state.get('visible'));
  case TOGGLE_LOCK_FAVOURITE_TAG:
    return state.update('lockedTags', lockedTags => toggleLock(lockedTags, action.name, action.visibility));
  default:
    return state;
  }
}
