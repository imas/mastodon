import classNames from 'classnames';
import PropTypes from 'prop-types';

const Foldable = ({ isVisible, className, children }) => (
  <div className={classNames('foldable', className, { 'foldable--visible': isVisible })}>
    <div className='foldable__inner'>
      {children}
    </div>
  </div>
);

Foldable.propTypes = {
  isVisible: PropTypes.bool.isRequired,
  className: PropTypes.string,
  children: PropTypes.node.isRequired,
};

export default Foldable;
