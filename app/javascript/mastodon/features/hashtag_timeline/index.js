import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from './containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import ColumnSettingsContainer from './containers/column_settings_container';
import {
  refreshHashtagTimeline,
  expandHashtagTimeline,
} from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { FormattedMessage } from 'react-intl';
import { connectHashtagStream } from '../../actions/streaming';

const mapStateToProps = (state, props) => ({
  hasUnread: state.getIn(['timelines', `hashtag:${props.params.id}`, 'unread']) > 0,
  isLocal: state.getIn(['settings', 'tag', `${props.params.id}`, 'shows', 'local'], false),
});

@connect(mapStateToProps)
export default class HashtagTimeline extends React.PureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    isLocal: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('HASHTAG', { id: this.props.params.id }));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  _subscribe (dispatch, id, isLocal) {
    this.disconnect = dispatch(connectHashtagStream(id, isLocal));
  }

  _unsubscribe () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  componentDidMount () {
    const { dispatch, isLocal } = this.props;
    const { id } = this.props.params;

    dispatch(refreshHashtagTimeline(id, isLocal));
    this._subscribe(dispatch, id, isLocal);
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.id !== this.props.params.id || nextProps.isLocal !== this.props.isLocal) {
      this.props.dispatch(refreshHashtagTimeline(nextProps.params.id, nextProps.isLocal));
      this._unsubscribe();
      this._subscribe(this.props.dispatch, nextProps.params.id, nextProps.isLocal);
    }
  }

  componentWillUnmount () {
    this._unsubscribe();
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = () => {
    this.props.dispatch(expandHashtagTimeline(this.props.params.id, this.props.isLocal));
  }

  render () {
    const { hasUnread, columnId, multiColumn } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='hashtag'
          active={hasUnread}
          title={id}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          showBackButton
        >
          <ColumnSettingsContainer
            tag={id}
          />
        </ColumnHeader>

        <StatusListContainer
          tag={id}
          trackScroll={!pinned}
          scrollKey={`hashtag_timeline-${columnId}`}
          timelineId={`hashtag:${id}`}
          loadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.hashtag' defaultMessage='There is nothing in this hashtag yet.' />}
        />
      </Column>
    );
  }

}
