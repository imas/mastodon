import api from '../api';

export const TREND_TAGS_SUCCESS = 'TREND_TAGS_SUCCESS';

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
