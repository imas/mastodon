import api from '../api';

export const FAVOURITE_TAGS_SUCCESS = 'FAVOURITE_TAGS_SUCCESS';
export const TOGGLE_FAVOURITE_TAGS = 'TOGGLE_FAVOURITE_TAGS';
export const COMPOSE_LOCK_TAG = 'LOCK_TAG';

export function refreshFavouriteTags() {
  return (dispatch, getState) => {
    api(getState).get('/api/v1/favourite_tags').then(response => {
      dispatch(refreshFavouriteTagsSuccess(response.data));
    });
  };
}

export function addFavouriteTags(tag, visibility) {
  return (dispatch, getState) => {
    api(getState).post('/api/v1/favourite_tags', {
      tag: tag,
      visibility: visibility,
    }).then(() => {
      dispatch(refreshFavouriteTags());
    });
  };
}

export function removeFavouriteTags(tag) {
  return (dispatch, getState) => {
    api(getState).delete(`/api/v1/favourite_tags/${tag}`).then(() => {
      dispatch(refreshFavouriteTags());
    });
  };
}

export function toggleFavouriteTags() {
  return {
    type: TOGGLE_FAVOURITE_TAGS,
  };
}

export function lockTagCompose(tag, visibility) {
  return {
    type: COMPOSE_LOCK_TAG,
    tag,
    visibility,
  };
}

export function refreshFavouriteTagsSuccess(tags) {
  return {
    type: FAVOURITE_TAGS_SUCCESS,
    tags,
  };
}
