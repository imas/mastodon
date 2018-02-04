import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import Link from 'react-router-dom/Link';

export default class Announcements extends React.PureComponent {

  static propTypes = {
    visible: PropTypes.bool.isRequired,
    onToggle: PropTypes.func.isRequired,
    announcements: ImmutablePropTypes.list.isRequired,
  };

  render () {
    const { visible, onToggle, announcements } = this.props;
    const caretClass = visible ? 'fa fa-caret-down' : 'fa fa-caret-up';
    const newIcon = '<img draggable="false" class="emojione" alt="new" title=":new:" src="/emoji/1f195.svg">';

    return (
      <div className='announcements'>
        <div className='compose__extra__header'>
          <i className='fa fa-bell' />
          <FormattedMessage id='announcement.title' defaultMessage='information' />
          <button className='compose__extra__header__icon' onClick={onToggle} >
            <i className={caretClass} />
          </button>
        </div>
        { visible && (
          <ul>
            {announcements.map((announcement, idx) => (
              <li key={idx}>
                <div className='announcements__body'>
                  <p dangerouslySetInnerHTML={{ __html: (announcement.get('is_new') ? newIcon : '') + announcement.get('body') }} />
                  <div className='links'>
                    {announcement.get('links').map((link, i) => {
                      if (link.get('url').indexOf('/') === 0) {
                        return (
                          <Link to={link.get('url')} key={i}>{link.get('text')}</Link>
                        );
                      } else {
                        return (
                          <a href={link.get('url')} target='_blank' key={i}>{link.get('text')}</a>
                        );
                      }
                    })}
                  </div>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    );
  }

}
