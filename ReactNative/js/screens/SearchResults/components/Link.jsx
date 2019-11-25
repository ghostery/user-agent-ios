/* eslint-disable react/prop-types */
/* eslint-disable no-underscore-dangle */
/* eslint-disable react/jsx-props-no-spreading */
/*!
 * Copyright (c) 2014-present Cliqz GmbH. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import React from 'react';
import { TouchableWithoutFeedback, View, Platform } from 'react-native';
import { withCliqz } from '../../../contexts/cliqz';

class Link extends React.Component {
  _onPress = e => {
    const { cliqz, url, onPress } = this.props;
    let { action, param } = this.props;
    e.stopPropagation();
    const { mobileCards } = cliqz;
    action = url ? 'openLink' : action;
    param = url || param;
    if (action) {
      mobileCards[action](param);
    }
    // callback onPress
    if (onPress) {
      onPress(e);
    }
  };

  render() {
    const { style, label, url, children } = this.props;
    return Platform.select({
      default: (
        <TouchableWithoutFeedback onPress={this._onPress}>
          <View {...this.props} />
        </TouchableWithoutFeedback>
      ),
      web: (
        <View style={style}>
          <div
            aria-label={label}
            data-url={url}
            onClick={this._onPress}
            role="presentation"
          >
            {children}
          </div>
        </View>
      ),
    });
  }
}

export default withCliqz(Link);
