import React from 'react';
import { Container, Image, ImageContainer } from '../styles/pages/property';
import { Button } from "@taikai/rocket-kit";

export default function Property() {
  function buyProperty() { }
  function listProperty() { }
  function sellProperty() { }
  return (
    <Container>
      <ImageContainer>
        {/* <Image src="/sea_view.png" alt="" /> */}
        <Button
          ariaLabel="Buy"
          className="button"
          color="green"
          value="Connect"
          variant="solid"
          action={() => buyProperty()}
        />
        <Button
          ariaLabel="List"
          className="button"
          color="green"
          value="Connect"
          variant="solid"
          action={() => listProperty()}
        />
        <Button
          ariaLabel="Sell"
          className="button"
          color="green"
          value="Connect"
          variant="solid"
          action={() => sellProperty()}

        />

      </ImageContainer>
    </Container>
  );
}
