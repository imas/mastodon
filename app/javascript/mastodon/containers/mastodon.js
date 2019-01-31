import React from 'react';
import { Provider, connect } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import { showOnboardingOnce } from '../actions/tutorial';
import { INTRODUCTION_VERSION } from '../actions/onboarding';
import { BrowserRouter, Route } from 'react-router-dom';
import { ScrollContext } from 'react-router-scroll-4';
import UI from '../features/ui';
import Introduction from '../features/introduction';
import { fetchCustomEmojis } from '../actions/custom_emojis';
import { hydrateStore } from '../actions/store';
import { connectUserStream } from '../actions/streaming';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';
import initialState from '../initial_state';
import { connectCommandStream } from '../actions/commands';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export const store = configureStore();
const hydrateAction = hydrateStore(initialState);

store.dispatch(hydrateAction);
store.dispatch(fetchCustomEmojis());

const mapStateToProps = state => ({
  showIntroduction: state.getIn(['settings', 'introductionVersion'], 0) < INTRODUCTION_VERSION,
});

@connect(mapStateToProps)
class MastodonMount extends React.PureComponent {

  static propTypes = {
    showIntroduction: PropTypes.bool,
  };

  render () {
    const { showIntroduction } = this.props;

    // im@stodon専用のがあるので無効化
    if (false && showIntroduction) {
      return <Introduction />;
    }

    return (
      <BrowserRouter basename='/web'>
        <ScrollContext>
          <Route path='/' component={UI} />
        </ScrollContext>
      </BrowserRouter>
    );
  }

}

export default class Mastodon extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  componentDidMount() {
    this.disconnect = store.dispatch(connectUserStream());
    this.commandDisconnect = store.dispatch(connectCommandStream());

    // Desktop notifications
    // Ask after 1 minute
    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      window.setTimeout(() => Notification.requestPermission(), 60 * 1000);
    }

    store.dispatch(showOnboardingOnce());
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
    if (this.commandDisconnect) {
      this.commandDisconnect();
      this.commandDisconnect = null;
    }
  }

  render () {
    const { locale } = this.props;

    return (
      <IntlProvider locale={locale} messages={messages}>
        <Provider store={store}>
          <MastodonMount />
        </Provider>
      </IntlProvider>
    );
  }

}
