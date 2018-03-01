import api from '../api';

export const TREND_TAGS_SUCCESS = 'TREND_TAGS_SUCCESS';
export const TOGGLE_TREND_TAGS = 'TOGGLE_TREND_TAGS';

export function refreshTrendTags() {
  return (dispatch, getState) => {
    api(getState).get('/api/v1/trend_tags').then(response => {
      dispatch(refreshTrendTagsSuccess(response.data));
    });
  };
}

export function refreshTrendTagsSuccess(tags) {
  return {
    type: TREND_TAGS_SUCCESS,
    tags,
  };
}

export function toggleTrendTags() {
  return {
    type: TOGGLE_TREND_TAGS,
  };
}
