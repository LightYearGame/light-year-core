const ShipConfig = artifacts.require("ShipConfig");
const HeroConfig = artifacts.require("HeroConfig");

const Registry = artifacts.require("Registry");
const Ship = artifacts.require("Ship");
const Hero = artifacts.require("Hero");

module.exports = async function (deployer) {

    //registry
    // await deployer.deploy(Registry);
    // const registry = await Registry.deployed();
    const registry = await Registry.at('0xE3B7f2e2Aa898153beeE6Df61eE3b818212a7F47');

    //ship config
    await deployer.deploy(ShipConfig, registry.address);
    const shipConfig = await ShipConfig.deployed();
    await registry.setShipConfig(shipConfig.address);

    //hero config
    await deployer.deploy(HeroConfig, registry.address);
    const heroConfig = await HeroConfig.deployed();
    await registry.setHeroConfig(heroConfig.address);

    //ship
    await deployer.deploy(Ship, registry.address);
    const ship = await Ship.deployed();
    await registry.setShip(ship.address);

    //hero
    await deployer.deploy(Hero, registry.address);
    const hero = await Hero.deployed();
    await registry.setHero(hero.address);

};
