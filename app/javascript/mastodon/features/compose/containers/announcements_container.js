import { connect } from 'react-redux';
import Announcements from '../components/announcements';

const mapStateToProps = state => {
  return {
    announcements: state.getIn(['meta', 'announcements']),
  };
};

export default connect(mapStateToProps)(Announcements);
