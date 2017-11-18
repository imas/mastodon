import React from 'react';
import { List as ImmutableList } from 'immutable';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Link from 'react-router-dom/Link';
import { defineMessages, injectIntl } from 'react-intl';
import IconButton from '../../../components/announcement_icon_button';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';

const Collapsable = ({ fullHeight, minHeight, isVisible, children }) => (
  <Motion defaultStyle={{ height: isVisible ? fullHeight : minHeight }} style={{ height: spring(!isVisible ? minHeight : fullHeight) }}>
    {({ height }) =>
      <div style={{ height: `${height}px`, overflow: 'hidden' }}>
        {children}
      </div>
    }
  </Motion>
);

Collapsable.propTypes = {
  fullHeight: PropTypes.number.isRequired,
  minHeight: PropTypes.number.isRequired,
  isVisible: PropTypes.bool.isRequired,
  children: PropTypes.node.isRequired,
};

const messages = defineMessages({
  toggle_visible: { id: 'media_gallery.toggle_visible', defaultMessage: 'Toggle visibility' },
});

class Announcements extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    announcements: ImmutablePropTypes.list,
  };

  state = {
    showList: ImmutableList(),
  };

  componentWillMount() {
    this.setState({ showList: this.props.announcements.map(v => v === undefined) });
  }

  onClick = (e) => {
    var index = e.currentTarget.parentNode.getAttribute('data-id');
    this.setState(({ showList }) => ({ showList: showList.update(index, v => !v) }));
  }

  render () {
    const { intl, announcements } = this.props;

    return (
      <ul className='announcements'>
        {announcements.map((announcement, i) =>
          <li key={i}>
            <Collapsable isVisible={this.state.showList.get(i)} fullHeight={300} minHeight={20} >
              <div className='announcements__body'>
                <p>
                  {announcement.get('title')}
                  <br />
                  <br />
                  <span dangerouslySetInnerHTML={{ __html: announcement.get('body') }} />
                </p>
                {announcement.get('link').map((link) => {
                  if (link.get('is_outer_link')) {
                    return (
                      <a href={link.get('url')} target='_blank'>{link.get('name')}</a>
                    );
                  } else {
                    return (
                      <Link key={link.get('url')} to={link.get('url')}>{link.get('name')}</Link>
                    );
                  }
                })}
              </div>
            </Collapsable>
            <div className='announcements__icon' data-id={i}>
              <IconButton title={intl.formatMessage(messages.toggle_visible)} icon='caret-up' onClick={this.onClick} size={20} animate active={this.state.showList.get(i)} />
            </div>
          </li>
        )}
      </ul>
    );
  }

}

export default injectIntl(Announcements);
