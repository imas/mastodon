import PropTypes from 'prop-types';
import React from 'react';

import spring from 'react-motion/lib/spring';

import Motion from '../features/ui/util/optional_motion';


const Foldable = ({ fullHeight, minHeight, isVisible, children }) => (
  <Motion defaultStyle={{ height: isVisible ? fullHeight : minHeight }} style={{ height: spring(!isVisible ? minHeight : fullHeight) }}>
    {({ height }) =>
      (<div style={{ height: `${height}px`, maxHeight: '20vh' }} className='scrollable optionally-scrollable'>
        {children}
      </div>)
    }
  </Motion>
);

Foldable.propTypes = {
  fullHeight: PropTypes.number.isRequired,
  minHeight: PropTypes.number.isRequired,
  isVisible: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
};

export default Foldable;
