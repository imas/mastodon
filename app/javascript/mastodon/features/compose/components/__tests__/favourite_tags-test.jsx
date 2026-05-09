
import { IntlProvider } from 'react-intl';

import { MemoryRouter } from 'react-router';

import { fromJS, List as ImmutableList } from 'immutable';

import renderer from 'react-test-renderer';

import { render, fireEvent, screen, waitFor } from '@/testing/rendering';

import FavouriteTags from '../favourite_tags';

const renderTree = (ui) => renderer.create(
  <MemoryRouter>
    <IntlProvider locale='en'>{ui}</IntlProvider>
  </MemoryRouter>
);

describe('<FavouriteTags />', () => {
  const sampleTags = fromJS([
    { id: '1', name: 'foo', visibility: 'public' },
    { id: '2', name: 'bar', visibility: 'unlisted' },
  ]);

  it('tagsが空かつvisible=falseのときの表示', () => {
    const refreshFavouriteTags = vi.fn();
    const onToggle = vi.fn();
    const onLockTag = vi.fn();
    const tree = renderTree(
      <FavouriteTags
        visible={false}
        tags={ImmutableList()}
        refreshFavouriteTags={refreshFavouriteTags}
        onToggle={onToggle}
        onLockTag={onLockTag}
      />
    ).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('tagsに2件・visible=trueのときの表示', () => {
    const refreshFavouriteTags = vi.fn();
    const onToggle = vi.fn();
    const onLockTag = vi.fn();
    const tree = renderTree(
      <FavouriteTags
        visible
        tags={sampleTags}
        refreshFavouriteTags={refreshFavouriteTags}
        onToggle={onToggle}
        onLockTag={onLockTag}
      />
    ).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('マウント時にrefreshFavouriteTagsが呼ばれる', () => {
    const refreshFavouriteTags = vi.fn();
    const onToggle = vi.fn();
    const onLockTag = vi.fn();
    render(
      <FavouriteTags
        visible
        tags={ImmutableList()}
        refreshFavouriteTags={refreshFavouriteTags}
        onToggle={onToggle}
        onLockTag={onLockTag}
      />
    );
    expect(refreshFavouriteTags).toHaveBeenCalledTimes(1);
  });

  it('FoldButtonのクリックでonToggleが呼ばれる', () => {
    const refreshFavouriteTags = vi.fn();
    const onToggle = vi.fn();
    const onLockTag = vi.fn();
    render(
      <FavouriteTags
        visible
        tags={sampleTags}
        refreshFavouriteTags={refreshFavouriteTags}
        onToggle={onToggle}
        onLockTag={onLockTag}
      />
    );
    fireEvent.click(screen.getByTitle('Toggle visibility'));
    expect(onToggle).toHaveBeenCalledTimes(1);
  });

  it('タグのlockボタンクリックでロック追加されonLockTagが呼ばれる', async () => {
    const refreshFavouriteTags = vi.fn();
    const onToggle = vi.fn();
    const onLockTag = vi.fn();
    const { container } = render(
      <FavouriteTags
        visible
        tags={sampleTags}
        refreshFavouriteTags={refreshFavouriteTags}
        onToggle={onToggle}
        onLockTag={onLockTag}
      />
    );
    const lockButtons = container.querySelectorAll('button.favourite-tags__lock');
    fireEvent.click(lockButtons[0]);
    await waitFor(() => {
      expect(onLockTag).toHaveBeenCalledWith('#foo', 'public');
    });
  });

  it('同一nameで異なるvisibilityのタグが両方リスト表示される', () => {
    const dupTags = fromJS([
      { id: '10', name: 'mor', visibility: 'public' },
      { id: '11', name: 'mor', visibility: 'unlisted' },
    ]);
    const refreshFavouriteTags = vi.fn();
    const onToggle = vi.fn();
    const onLockTag = vi.fn();
    const { container } = render(
      <FavouriteTags
        visible
        tags={dupTags}
        refreshFavouriteTags={refreshFavouriteTags}
        onToggle={onToggle}
        onLockTag={onLockTag}
      />
    );
    expect(container.querySelectorAll('.compose__extra__body > li').length).toBe(2);
  });

  it('複数のタグを順にロックすると最後のonLockTag呼び出しに両方含まれる', async () => {
    const refreshFavouriteTags = vi.fn();
    const onToggle = vi.fn();
    const onLockTag = vi.fn();
    const { container } = render(
      <FavouriteTags
        visible
        tags={sampleTags}
        refreshFavouriteTags={refreshFavouriteTags}
        onToggle={onToggle}
        onLockTag={onLockTag}
      />
    );
    const lockButtons = container.querySelectorAll('button.favourite-tags__lock');
    fireEvent.click(lockButtons[0]);
    fireEvent.click(lockButtons[1]);
    await waitFor(() => {
      // visibilityIconsをreverseしてfindするため
      // public/unlistedの両方含む場合は最も制限の弱い`unlisted`が選ばれる
      expect(onLockTag).toHaveBeenLastCalledWith('#foo #bar', 'unlisted');
    });
  });
});
