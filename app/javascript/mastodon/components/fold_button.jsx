import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import classNames from 'classnames';

import { Icon } from '@/mastodon/components/icon';
import ArrowDropDownIcon from '@/material-icons/400-24px/arrow_drop_down.svg?react';

export default class FoldButton extends PureComponent {

  static propTypes = {
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

  handleClick = (e) => {
    e.preventDefault();
    if (!this.props.disabled && this.props.onClick) {
      this.props.onClick(e);
    }
  };

  render () {
    const style = {
      fontSize: `${this.props.size}px`,
      width: `${this.props.size * 1.28571429}px`,
      height: `${this.props.size * 1.28571429}px`,
      lineHeight: `${this.props.size}px`,
      ...this.props.style,
      ...(this.props.active ? this.props.activeStyle : {}),
    };

    const {
      active,
      animate,
      className,
      disabled,
      expanded,
      inverted,
      overlay,
      pressed,
      tabIndex,
      title,
    } = this.props;

    const classes = classNames(className, 'icon-button', {
      active,
      disabled,
      inverted,
      overlayed: overlay,
    });

    const iconStyle = animate ? {
      transform: `rotate(${active ? 180 : 0}deg)`,
      transition: 'transform 300ms ease-in-out'
    } : {
      transform: `rotate(${active ? 180 : 0}deg)`
    };

    return (
      <button
        aria-label={title}
        aria-pressed={pressed}
        aria-expanded={expanded}
        title={title}
        className={classes}
        onClick={this.handleClick}
        style={style}
        tabIndex={tabIndex}
      >
        <Icon id='down' icon={ArrowDropDownIcon} className='compose__extra__header__icon' style={iconStyle} />
      </button>
    );
  }

}
