import { connect } from 'react-redux';
import Announcements from '../components/announcements';

const mapStateToProps = state => {
  return {
    homeSize: state.getIn(['timelines', 'home', 'items']).size,
    isLoading: state.getIn(['timelines', 'home', 'isLoading']),
    announcements: state.getIn(['meta', 'announcements']),
  };
};

export default connect(mapStateToProps)(Announcements);
