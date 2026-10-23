import api from '../api';

export const FAVOURITE_TAGS_SUCCESS = 'FAVOURITE_TAGS_SUCCESS';
export const TOGGLE_FAVOURITE_TAGS = 'TOGGLE_FAVOURITE_TAGS';
export const COMPOSE_LOCK_TAG = 'LOCK_TAG';
export const TOGGLE_LOCK_FAVOURITE_TAG = 'TOGGLE_LOCK_FAVOURITE_TAG';

// 公開範囲の狭いものから順に並べる。ロック中のタグのうち最も狭い公開範囲を投稿に使う
const narrowerVisibilities = ['private', 'unlisted', 'public'];

export function refreshFavouriteTags() {
  return (dispatch, getState) => {
    api(getState).get('/api/v1/favourite_tags').then(response => {
      dispatch(refreshFavouriteTagsSuccess(response.data));
    }).catch(() => {});
  };
}

export function addFavouriteTags(tag, visibility) {
  return (dispatch, getState) => {
    api(getState).post('/api/v1/favourite_tags', {
      name: tag,
      visibility: visibility,
    }).then(() => {
      dispatch(refreshFavouriteTags());
    }).catch(() => {});
  };
}

export function removeFavouriteTags(id) {
  return (dispatch, getState) => {
    api(getState).delete(`/api/v1/favourite_tags/${id}`).then(() => {
      dispatch(refreshFavouriteTags());
    }).catch(() => {});
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

// ロック中のタグは投稿欄を閉じても残るよう redux に置き、本文への差し込みは compose 側の LOCK_TAG に任せる
export function toggleLockFavouriteTag(name, visibility) {
  return (dispatch, getState) => {
    dispatch({
      type: TOGGLE_LOCK_FAVOURITE_TAG,
      name,
      visibility,
    });

    const lockedTags = getState().getIn(['favourite_tags', 'lockedTags']);
    const lockedVisibility = narrowerVisibilities.find(v => lockedTags.some(tag => tag.get('visibility') === v));
    dispatch(lockTagCompose(
      lockedTags.map(tag => `#${tag.get('name')}`).join(' '),
      lockedVisibility ?? '',
    ));
  };
}

export function refreshFavouriteTagsSuccess(tags) {
  return {
    type: FAVOURITE_TAGS_SUCCESS,
    tags,
  };
}
