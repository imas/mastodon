import { TREND_TAGS_SUCCESS } from '../actions/trend_tags';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  tags: Immutable.Map({
    updated_at: '',
    score: Immutable.Map(),
  }),
});

export default function trend_tags(state = initialState, action) {
  switch(action.type) {
  case TREND_TAGS_SUCCESS:
    const tmp = Immutable.fromJS(action.tags);
    return state.set('tags', tmp.set('score', tmp.get('score').sort((a, b) => {
      return b - a; 
    })));
  default:
    return state;
  }
}
