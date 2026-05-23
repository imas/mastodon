import { IntlProvider } from 'react-intl';

import renderer from 'react-test-renderer';

import { render, fireEvent, screen } from '@/testing/rendering';

import FavouriteToggle from '../favourite_toggle';

const renderWithIntl = (ui) => renderer.create(<IntlProvider locale='en'>{ui}</IntlProvider>);

describe('<FavouriteToggle />', () => {
  it('publicId/unlistedIdがnullの場合は両方の追加ボタンが表示される', () => {
    const noop = vi.fn();
    const tree = renderWithIntl(
      <FavouriteToggle tag='test' addFavouriteTags={noop} removeFavouriteTags={noop} />
    ).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('publicIdが指定されている場合はpublicに対応する削除ボタンが表示される', () => {
    const noop = vi.fn();
    const tree = renderWithIntl(
      <FavouriteToggle tag='test' publicId={1} addFavouriteTags={noop} removeFavouriteTags={noop} />
    ).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('publicId/unlistedIdの両方が指定されている場合は両方の削除ボタンが表示される', () => {
    const noop = vi.fn();
    const tree = renderWithIntl(
      <FavouriteToggle tag='test' publicId={1} unlistedId={2} addFavouriteTags={noop} removeFavouriteTags={noop} />
    ).toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('publicの追加ボタン押下でaddFavouriteTagsがtagと"public"で呼ばれる', () => {
    const addHandler = vi.fn();
    const noop = vi.fn();
    render(<FavouriteToggle tag='test' addFavouriteTags={addHandler} removeFavouriteTags={noop} />);
    fireEvent.click(screen.getAllByRole('button')[0]);
    expect(addHandler).toHaveBeenCalledWith('test', 'public');
  });

  it('unlistedの追加ボタン押下でaddFavouriteTagsがtagと"unlisted"で呼ばれる', () => {
    const addHandler = vi.fn();
    const noop = vi.fn();
    render(<FavouriteToggle tag='test' addFavouriteTags={addHandler} removeFavouriteTags={noop} />);
    fireEvent.click(screen.getAllByRole('button')[1]);
    expect(addHandler).toHaveBeenCalledWith('test', 'unlisted');
  });

  it('publicの削除ボタン押下でremoveFavouriteTagsがpublicIdで呼ばれる', () => {
    const removeHandler = vi.fn();
    const noop = vi.fn();
    render(<FavouriteToggle tag='test' publicId={42} addFavouriteTags={noop} removeFavouriteTags={removeHandler} />);
    fireEvent.click(screen.getAllByRole('button')[0]);
    expect(removeHandler).toHaveBeenCalledWith(42);
  });

  it('unlistedの削除ボタン押下でremoveFavouriteTagsがunlistedIdで呼ばれる', () => {
    const removeHandler = vi.fn();
    const noop = vi.fn();
    render(<FavouriteToggle tag='test' unlistedId={99} addFavouriteTags={noop} removeFavouriteTags={removeHandler} />);
    fireEvent.click(screen.getAllByRole('button')[1]);
    expect(removeHandler).toHaveBeenCalledWith(99);
  });
});
