import { memo, useCallback } from 'react';

import classNames from 'classnames';
import PropTypes from 'prop-types';

import { Icon } from '@/mastodon/components/icon';
import ArrowDropDownIcon from '@/material-icons/400-24px/arrow_drop_down.svg?react';

const FoldButton = ({
  active,
  activeStyle,
  animate,
  className,
  disabled,
  expanded,
  inverted,
  onClick,
  overlay,
  pressed,
  size,
  style,
  tabIndex,
  title,
}) => {
  const handleClick = useCallback((e) => {
    e.preventDefault();
    if (!disabled && onClick) {
      onClick(e);
    }
  }, [disabled, onClick]);

  const buttonStyle = {
    fontSize: `${size}px`,
    width: `${size * 1.28571429}px`,
    height: `${size * 1.28571429}px`,
    lineHeight: `${size}px`,
    ...style,
    ...(active ? activeStyle : {}),
  };

  const classes = classNames(className, 'icon-button', {
    active,
    disabled,
    inverted,
    overlayed: overlay,
  });

  const iconStyle = animate ? {
    transform: `rotate(${active ? 180 : 0}deg)`,
    transition: 'transform 300ms ease-in-out',
  } : {
    transform: `rotate(${active ? 180 : 0}deg)`,
  };

  return (
    <button
      aria-label={title}
      aria-pressed={pressed}
      aria-expanded={expanded}
      title={title}
      className={classes}
      onClick={handleClick}
      style={buttonStyle}
      tabIndex={tabIndex}
    >
      <Icon id='down' icon={ArrowDropDownIcon} className='compose__extra__header__icon' style={iconStyle} />
    </button>
  );
};

FoldButton.propTypes = {
  active: PropTypes.bool,
  activeStyle: PropTypes.object,
  animate: PropTypes.bool,
  className: PropTypes.string,
  disabled: PropTypes.bool,
  expanded: PropTypes.bool,
  inverted: PropTypes.bool,
  onClick: PropTypes.func,
  overlay: PropTypes.bool,
  pressed: PropTypes.bool,
  size: PropTypes.number,
  style: PropTypes.object,
  tabIndex: PropTypes.number,
  title: PropTypes.string,
};

export default memo(FoldButton);
