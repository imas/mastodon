import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import SettingToggle from '../components/setting_toggle';
import SettingText from '../components/setting_text';
import { Map as ImmutableMap } from 'immutable';

const messages = defineMessages({
  filter_regex: { id: 'tag.column_settings.filter_regex', defaultMessage: 'Filter out by regular expressions' },
  settings: { id: 'tag.settings', defaultMessage: 'Column settings' },
});

@injectIntl
export default class ColumnSettings extends React.PureComponent {

  static propTypes = {
    tagId: ImmutablePropTypes.number.isRequired,
    settings: ImmutablePropTypes.map.isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { tagId, settings, onChange, intl } = this.props;
    const initialSettings = ImmutableMap({
      shows: ImmutableMap({
        local: false,
        reply: true,
      }),

      regex: ImmutableMap({
        body: '',
      }),
    });

    return (
      <div>
        <span className='column-settings__section'><FormattedMessage id='tag.column_settings.basic' defaultMessage='Basic' /></span>

        <div className='column-settings__row'>
          <SettingToggle tagId={tagId} prefix='hashtag_timeline' settings={settings.get(`${tagId}`, initialSettings)} settingKey={['shows', 'local']} onChange={onChange} label={<FormattedMessage id='tag.column_settings.show_local_only' defaultMessage='Show local only' />} />
        </div>

        <div className='column-settings__row'>
          <SettingToggle tagId={tagId} prefix='hashtag_timeline' settings={settings.get(`${tagId}`, initialSettings)} settingKey={['shows', 'reply']} onChange={onChange} label={<FormattedMessage id='tag.column_settings.show_replies' defaultMessage='Show replies' />} />
        </div>

        <span className='column-settings__section'><FormattedMessage id='tag.column_settings.advanced' defaultMessage='Advanced' /></span>

        <div className='column-settings__row'>
          <SettingText tagId={tagId} prefix='hashtag_timeline' settings={settings.get(`${tagId}`, initialSettings)} settingKey={['regex', 'body']} onChange={onChange} label={intl.formatMessage(messages.filter_regex)} />
        </div>
      </div>
    );
  }

}
