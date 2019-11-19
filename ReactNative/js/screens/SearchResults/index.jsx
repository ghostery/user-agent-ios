/* eslint-disable react/prop-types */
import React from 'react';
import Results from './components/Results';
import Cliqz from './services/cliqz-wrapper';

export default class SearchResults extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      results: {},
      query: '',
    };
    this.searchRef = React.createRef();
    this.onAction = this.onAction.bind(this);
    this.onResults = this.onResults.bind(this);
    const { bridgeManager } = this.props;
    this.cliqz = new Cliqz(bridgeManager.inject);
  }

  // eslint-disable-next-line react/no-deprecated
  componentWillMount() {
    const { bridgeManager, events } = this.props;
    bridgeManager.addActionListener(this.onAction);
    events.sub('search:results', this.onResults);
  }

  componentWillUnmount() {
    const { bridgeManager, events } = this.props;
    bridgeManager.removeActionListener(this.onAction);
    events.un_sub('search:results', this.onResults);
  }

  onAction({ module, action, args /* , id */ }) {
    if (module === 'search' && action === 'startSearch') {
      const query = args[0];
      this.setState({ query });
    }

    if (module === 'search' && action === 'stopSearch') {
      this.setState({
        results: {
          results: [],
          meta: {},
        },
      });
    }
  }

  onResults(results) {
    this.setState({ results });
  }

  render() {
    const { query, results } = this.state;

    // eslint-disable-next-line prettier/prettier
    return <Results
      results={results}
      query={query}
      cliqz={this.cliqz}
    />;
  }
}
